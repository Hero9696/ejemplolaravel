import { Textarea } from '@/components/ui/textarea';
import AppLayout from '@/layouts/app-layout';
import { type BreadcrumbItem } from '@/types';
import { Head, useForm } from '@inertiajs/react';

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Product Edit',
        href: '/products/create',
    },
];

interface Product {
    id: number;
    name: string;
    stock: number;
    price: number;
    description: string;
}

export default function ProductEdit({ product }: { product: Product }) {
    /* , processing, errors  */
    const { data, setData, put, errors, processing } = useForm({
        name: product.name,
        description: product.description,
        stock: product.stock,
        price: product.price,
    });

    const handleUpdate = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        put(String(route('products.update', product.id)));
    };

    return (
        <AppLayout breadcrumbs={breadcrumbs}>
            <Head title="Product Create" />
            <div className="w-8/12 p-4">
                <form
                    onSubmit={handleUpdate}
                    action="post"
                    className="space-y-4"
                >
                    <div className="gap-1.5">
                        <input
                            type="text"
                            name="name"
                            placeholder="Product Name"
                            className="w-full border p-2"
                            value={data.name}
                            onChange={(e) => setData('name', e.target.value)}
                        />
                        {errors.name && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.name}
                            </div>
                        )}
                    </div>
                    <div className="gap-1.5">
                        <input
                            type="number"
                            name="stock"
                            placeholder="Product Stock"
                            className="w-full border p-2"
                            value={data.stock}
                            onChange={(e) =>
                                setData('stock', Number(e.target.value))
                            }
                        />
                        {errors.stock && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.stock}
                            </div>
                        )}
                    </div>
                    <div className="gap-1.5">
                        <input
                            type="number"
                            name="price"
                            placeholder="Product Price"
                            className="w-full border p-2"
                            value={data.price}
                            onChange={(e) =>
                                setData('price', Number(e.target.value))
                            }
                        />
                        {errors.price && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.price}
                            </div>
                        )}
                    </div>
                    <div className="gap-1.5">
                        <Textarea
                            placeholder="Product Description"
                            value={data.description}
                            onChange={(e) =>
                                setData('description', e.target.value)
                            }
                        />
                        {errors.description && (
                            <div className="mt-1 flex items-center text-sm text-red-500">
                                {errors.description}
                            </div>
                        )}
                    </div>
                    <button
                        type="submit"
                        className="bg-blue-500 p-2 text-white"
                        disabled={processing}
                    >
                        Update Product
                    </button>
                </form>
            </div>
        </AppLayout>
    );
}
